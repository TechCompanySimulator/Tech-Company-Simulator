local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

return function()
	local Table = loadModule("Table")
	local TableClass = loadModule("TableClass")

	local proxyTab1 = {
		Test = true;
		Hello = {
			Test2 = 5;
			Test3 = {
				Test4 = "ThisIsATest"
			}
		}
	}

	local proxyTab2 = {
		Test = true;
		Hello = {
			Test2 = 3;
			Test3 = {
				Test4 = "ThisIsATest"
			}
		}
	}

	describe("Table", function()
		it("should deep check the equality of two tables correctly, even if the tables have nested tables", function()
			local tabsEqual
			expect(function()
				tabsEqual = Table.deepCheckEquality(proxyTab1, proxyTab1)
			end).never.to.throw()
			expect(tabsEqual).to.equal(true)
			expect(Table.deepCheckEquality(proxyTab1, proxyTab2)).to.equal(false)
		end)

		it("should return whether the table contains a certain value or table", function()
			local tabContains
			expect(function()
				tabContains = Table.contains(proxyTab1.Hello, 5)
			end).never.to.throw()
			expect(tabContains).to.equal(true)
			expect(Table.contains(proxyTab1, {
				Test2 = 5;
				Test3 = {
					Test4 = "ThisIsATest"
				}
			})).to.equal(true)
			expect(Table.contains(proxyTab1, {
				Test2 = 3;
				Test3 = {
					Test4 = "ThisIsATest"
				}
			})).to.equal(false)
		end)

		it("should return the length of the table, even if it is a dictionary", function()
			local tabLength 
			expect(function()
				tabLength = Table.length(proxyTab1)
			end).never.to.throw()
			expect(tabLength).to.equal(2)
			expect(function()
				Table.length("Fail")
			end).to.throw()
		end)

		it("should create an exact clone of the given table", function()
			local tableClone
			expect(function()
				tableClone = Table.clone(proxyTab1)
			end).never.to.throw()
			expect(Table.deepCheckEquality(proxyTab1, tableClone)).to.equal(true)
			expect(function()
				Table.clone("Fail")
			end).to.throw()
		end)

		it("should return the index for the given value in the given table", function()
			local tableIndex
			expect(function()
				tableIndex = Table.getIndex(proxyTab1, {
					Test2 = 5;
					Test3 = {
						Test4 = "ThisIsATest"
					}
				})
			end).never.to.throw()
			expect(tableIndex).to.equal("Hello")
			expect(Table.getIndex(proxyTab1, "Fail")).never.to.be.ok()
		end)

		it("should remove all duplicates in a given list", function()
			local proxyTab3 = {
				"Test1";
				"Test2";
				"Test1";
				"Test3";
				"Test4";
				"Test1";
				"Test5";
			}
			local newTab 
			expect(function()
				newTab = Table.removeListDuplicates(proxyTab3)
			end).never.to.throw()
			expect(Table.length(newTab)).to.equal(5)
			expect(function()
				Table.removeListDuplicates("Fail")
			end).to.throw()
		end)

		it("should merge the two given tables, overwriting keys in previous tables which are in later tables", function()
			local newTab 
			expect(function()
				newTab = Table.merge(proxyTab1, proxyTab2)
			end).never.to.throw()
			expect(newTab.Hello.Test2).to.equal(3)
			expect(newTab.Hello.Test2).never.to.equal(proxyTab1.Hello.Test2)
			expect(function()
				Table.merge("Fail")
			end).to.throw()
		end)

		it("should follow the given path into a table and return the endpoint", function()
			local endpoint
			expect(function()
				endpoint = Table.followPath(proxyTab1, "Hello", "Test3")
			end).never.to.throw()
			expect(typeof(endpoint)).to.equal("table")
			expect(endpoint.Test4).to.equal("ThisIsATest")
			expect(Table.followPath(proxyTab1, "Hello", "Test100")).never.to.be.ok()
		end)

		it("should create the given path with a given start point and end point", function()
			local start = {}
			local endVal = 40
			local path = {"Test1", "Test2"}
			expect(function()
				Table.createPath(start, endVal, table.unpack(path))
			end).never.to.throw()

			local location = start
			for _, waypoint in ipairs(path) do
				if typeof(location) == "table" then
					location = location[waypoint]
				else
					return nil
				end
			end
			expect(location).to.equal(endVal)
		end)

		it("should return the number of duplicates a table has of a certain value", function()
			local testTab1 = {1;1;2;3;4;1;1;2;}
			local result1
			expect(function()
				result1 = Table.getNumDuplicates(testTab1, 1)
			end).never.to.throw()
			expect(result1).to.equal(4)
			local testTab2 = {{1;1;};{1;1;};{1;2;};{1;1;};{1;1;};}
			local result2 = Table.getNumDuplicates(testTab2, {1;1;})
			expect(result2).to.equal(4)
		end)

		it("should create a new table class and run metamethods on it successfully", function()
			local newTab1, newTab2, newTab3
			expect(function()
				newTab1 = TableClass.new(proxyTab1)
				newTab2 = TableClass.new(proxyTab2)
			end).never.to.throw()
			expect(newTab1 == newTab2).to.equal(false)
			expect(function()
				newTab3 = newTab1 .. newTab2
			end).never.to.throw()
			expect(Table.deepCheckEquality(proxyTab2, newTab3)).to.equal(true)
		end)
	end)
end